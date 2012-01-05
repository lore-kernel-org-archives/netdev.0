From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Thu, 5 Jan 2012 17:53:33 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF22286646025656@ORSMSX102.amr.corp.intel.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Michal Miroslaw <mirqus@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9743 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754282Ab2AERxg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 12:53:36 -0500
In-Reply-To: <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Micha=B3 Miros=B3aw [mailto:mirqus@gmail.com]
>Sent: Friday, December 23, 2011 9:59 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.org;
>gospo@redhat.com; sassmann@redhat.com; Waskiewicz Jr, Peter P
>Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal dat=
a
>
>2011/12/23 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
>> From: Don Skidmore <donald.c.skidmore@intel.com>
>>
>> Some of our adapters have thermal data available, this patch exports
>this
>> data via a read-only sysfs interface.
>
>Just curious: can't this use the hwmon subsystem to be consistent with
>other system monitoring devices?
>
>Best Regards,
>Micha=B3 Miros=B3aw

Sorry about the slow response, first vacation then I hadn't heard of hw=
mon and wanted to look into it a bit.  I can see why you mentioned it a=
s it looks to be close to what I'm trying to do here.  However I don't =
think it quite matches.  I'll list my thoughts below:

- We are trying to export a large set of data that our customers are re=
questing.  The thermals were just the first patch and the other data it=
ems wouldn't really fit well in the hwmon (i.e. FW version, secondary M=
AC address).
- Didn't seem like we had much data to offer hwmon anyway just sensor t=
emp, caution threshold, maxop threshold and location of sensor.  All th=
e other data (which you haven't seen yet so couldn't have known :) wasn=
't related.
- The thermal data we do have is defined in our FW and could change (nu=
mber of sensors) based on that FW.  I wasn't sure whether that would be=
 an issue for hwmon.
- I went with sysfs based on a conversation with Peter Waskiewicz.  He =
mentioned that there was discussion on how to export generic data at ne=
tconf and sysfs was brought up as the best choice.=20

Thanks for reviewing the patch and bring up this question. :)
-Don Skidmore <donald.c.skidmore@intel.com>




=20
