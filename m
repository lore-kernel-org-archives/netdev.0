From: Pelle Svensson <pelle2004@hotmail.com>
Subject: RE: Intel 82567LM e1000e DHCP problem/question
Date: Tue, 17 Mar 2009 13:17:44 +0100
Message-ID: <BAY143-W34F4C6B7F6B8E0F1D64531B9980@phx.gbl>
References: <BAY143-W41A6A9A51EDB64905CA4D1B99A0@phx.gbl>
	<alpine.WNT.2.00.0903161133100.5116@jbrandeb-desk1.amr.corp.intel.com>
 	<BAY143-W2353DFECB11A239842C4C3B99B0@phx.gbl>
 	<alpine.WNT.1.10.0903162202080.5440@jbrandeb-MOBL1.amr.corp.intel.com>
 <87mybk1otu.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <e1000-devel@lists.sourceforge.net>
To: <bjorn@mork.no>, <jesse.brandeburg@intel.comta>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s10.bay0.hotmail.com ([65.54.246.210]:22483 "EHLO
	BAY0-OMC3-S10.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753299AbZCQMRq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 08:17:46 -0400
In-Reply-To: <87mybk1otu.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




----------------------------------------
> From: bjorn@mork.no
> To: pelle2004@hotmail.com
> CC: jesse.brandeburg@intel.com; netdev@vger.kernel.org; e1000-devel@l=
ists.sourceforge.net
> Subject: Re: Intel 82567LM e1000e DHCP problem/question
> Date: Tue, 17 Mar 2009 10:27:41 +0100
>
> "Brandeburg, Jesse"  writes:
>> On Mon, 16 Mar 2009, Pelle Svensson wrote:
>>
>>> I tried to hit Ctrl-P frequently during the boot process but it new=
er display any
>>> management setup. I'm running Fedora 10 on Lenovo T500 bios 1.20 (6=
=46ET50WW).
>>
>> Okay, maybe there is a bios setting you can change.
>>
>> I am not experienced in configuring this on a t500, so I can't give =
you
>> direct instructions.
>
> Assuming it's similar to a Thinkpad X301:
>
> ThinkVantage -> F1 -> Config -> Intel(R) AMT -> Disable

I don't have that entry and it seems to be a mystery one.
This guy has 2 identical T500 and one dose not have AMT
http://forums.lenovo.com/lnv/board/message?board.id=3DT400_series_Think=
Pads&message.id=3D8826&query.id=3D116821#M8826

>
> Totally offtopic, but IBM used to have a nice support tool called BIO=
S
> simulators: http://www-307.ibm.com/pc/support/site.wss/TPAD-SIMS.html
> But I haven't been able to find such simulators for the newer Lenovo
> Thinkpads.
>

Nice tool but it is not up to date with an T500 entry as you say!


I'm more convinced now that it is AMT and that I need to get it turned =
off.

I did a session checking the DHCP Request when the cable is inserted.

- Power on=20
- Boot XP - No Request Until XP ready.
- Restart - Request start when XP shut down graphics.
- Reboot - Requests
- Enter Grub - Requests
- Boot Fedora - Requests
- Fedora up - No Request.

In this case XP shut down trigged the plugg Requests.
So either XP of Linux shutdown stasrt the request.
One thing notice is that the DHCP Transaction number for
XP and Linux has format 0x12345678 and Host option.
The one comming from AMT has format 0x123456
and no Host option.

The bottom line is that DHCP Server gives different IP
according to the Host name (same MAC).=20
This is right but there is a fault when the different hosts
are mixed frequently. Each MAC/Host dose not get the
same IP and thing start to get messy.

Have to look into that and leave AMT for the moment.

/Thanks

=20







_________________________________________________________________
Dela foton p=E5 ett smidigt s=E4tt med Windows Live=99 Photos.
http://www.microsoft.com/windows/windowslive/products/photos.aspx