From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Wed, 25 Mar 2015 11:29:10 +0200
Message-ID: <55127FE6.8030905@cloudius-systems.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com> <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com> <55113B9B.3090308@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com> <5511AFD6.2020406@cloudius-systems.com> <87618083B2453E4A8714035B62D6799250274F2A@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:36396 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbbCYJ3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 05:29:13 -0400
Received: by wgra20 with SMTP id a20so20071574wgr.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 02:29:12 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D6799250274F2A@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/25/15 00:50, Tantilov, Emil S wrote:
>> -----Original Message-----
>> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
>> Sent: Tuesday, March 24, 2015 11:41 AM
>> To: Tantilov, Emil S; netdev@vger.kernel.org
>> Cc: Kirsher, Jeffrey T; avi@cloudius-systems.com; gleb@cloudius-systems.com
>> Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>>
>>
>>
>>> On 03/24/15 20:12, Tantilov, Emil S wrote:
>>> BTW - there are other issues with your patches. The indirection table seems to come out as all 0s and the VF driver reports link down/up when querying it.
>> Worked just fine to me on x540.
>> What is your setup? How did u check it? Did u remember to patch "ip" tool and enable the querying?
> The issue with the link is that you do not have proper locking when calling the mailbox which is messing up the link check subtask. Basically you need to protect the calls to ixgbevf_get_rss_key and get_reta with the mbx_lock similar to how the driver does it in all cases where the mailbox is called.

:D Just wrote u the same thing in a reply on your first email...
Sure. Let me fix it in v8.

thanks,
vlad

>
> Thanks,
> Emil
>
