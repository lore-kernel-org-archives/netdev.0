From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: regression in ixgbe SFP detection patch
Date: Wed, 11 Nov 2015 14:09:54 -0800
Message-ID: <5643BCB2.6070104@gmail.com>
References: <20151111173527.GA3641@gandi.net>
 <87618083B2453E4A8714035B62D67992504DF0AA@FMSMSX105.amr.corp.intel.com>
 <20151111213458.GD3641@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Schmitt, Phillip J" <phillip.j.schmitt@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: William Dauchy <william@gandi.net>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33588 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbbKKWJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 17:09:56 -0500
Received: by pabfh17 with SMTP id fh17so42768277pab.0
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 14:09:55 -0800 (PST)
In-Reply-To: <20151111213458.GD3641@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2015 01:34 PM, William Dauchy wrote:
> On Nov11 20:33, Tantilov, Emil S wrote:
>> If the diff above is the patch you are referring to then you will break the
>> SFP+ detection in the case where the driver was loaded while there were no
>> SFP+ modules present in the cages.
> understood, I was surprised of the modification of behavior.

You might try testing against net-next to see if the problem still 
exists.  It looks like the code in question doesn't exist upstream as it 
was replaced in commit 45788d2af928 ("ixgbe: fix issue with sfp events 
with new X550 devices").

- Alex
