From: Ariel Elior <Ariel.Elior@qlogic.com>
Subject: RE: bnx2x - occasional high packet loss (on LAN)
Date: Mon, 21 Sep 2015 10:43:16 +0000
Message-ID: <81D78EA7F834FA4C83B64260D494C859087192AE@avmb3.qlogic.org>
References: <20150915041726.GD6850@pcnci.linuxbox.cz>
 <81D78EA7F834FA4C83B64260D494C8590870F221@avmb3.qlogic.org>
 <20150916081833.GE6850@pcnci.linuxbox.cz>
 <20150921103200.GF6850@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"nik@linuxbox.cz" <nik@linuxbox.cz>
To: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40038 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753996AbbIUKnW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 06:43:22 -0400
In-Reply-To: <20150921103200.GF6850@pcnci.linuxbox.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Nikola Ciprich [mailto:nikola.ciprich@linuxbox.cz]
> Sent: Monday, September 21, 2015 1:32 PM
> To: Ariel Elior <Ariel.Elior@qlogic.com>
> Cc: netdev <netdev@vger.kernel.org>; nik@linuxbox.cz
> Subject: Re: bnx2x - occasional high packet loss (on LAN)
> 
> Hello Ariel,
> 
> after few days of torturing NICs with flood pings, card
> seems to have given up with lots of errors..
> 
> I've uploaded new kernel log here:
> 
> http://nik.lbox.cz/download/dmesg.txt
> 
> Will this help?
> 
> I still have it in this hung state now, in case I could provide
> more info for diagnostics..
> 
> however please note this can be different problem then I was reporting
> originaly, since I only had high packet loss, while now whole card
> seems to be blocked..  but maybe it just is worse case of the same
> problem?

Hi Nikola,
Seems like the link below is the same file you shared before - I don't see any errors there.

Two things you can collect for me to help debug this issue:

1.
Output of ethtool -d eth1 after problem occurs (redirect to a file)

2.
dmesg after enabling link related debug messages. Use
modprobe bnx2x debug=0x4
Or
ethtool -s eth1 msglvl 0x4
to enable these prints.

This holds for both of your problems (unless it is the same issue).

Thanks,
Ariel
