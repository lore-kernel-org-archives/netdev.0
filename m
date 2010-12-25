From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [net-next-2.6 04/15] e1000e: checkpatch error - open braces
Date: Sat, 25 Dec 2010 14:10:38 +0100
Message-ID: <m3lj3eq9pt.fsf@intrepid.localdomain>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1293257174-15498-5-git-send-email-jeffrey.t.kirsher@intel.com>
	<4D15C77C.9030306@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:34018 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841Ab0LYNKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 08:10:52 -0500
In-Reply-To: <4D15C77C.9030306@garzik.org> (Jeff Garzik's message of "Sat, 25
	Dec 2010 05:29:16 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> writes:

>> ERROR: that open brace { should be on the previous line

>> -static const u16 e1000_gg82563_cable_length_table[] =
>> -	 { 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };

>> -	static const u32 test[] =
>> -		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};

> Gah, that looks worse than the unpatched code.
>
> I think this was an over-literal checkpatch interpretation.  If you
> look at e.g. drivers/net/tg3.c, you see that longer tables have the
> trailing braces on a separate line, where they should be.
>
> IMO, the single-line cases should just be left as they are now in the
> source code.

I think so. Also I think it's a false positive - the above aren't the
typical
	if()
		{
		xxx
		}

They are instead single lines:
	type var[] = {a, b, c, d};
broken into two to meet the (former) line length limit.

Makes me think that we should never break long lines in the code. This
is best left for the text editors and viewers (only while displaying).
-- 
Krzysztof Halasa
