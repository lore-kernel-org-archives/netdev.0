From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 05 Jan 2012 19:53:24 +0100
Message-ID: <1325789604.4759.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
	 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
	 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
	 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F0382BB.5060601@hp.com>
	 <CAL8zT=iSP+GncMEJ38eaCZ85P-tBDMUjUeaFr-x3j_rksUaK2A@mail.gmail.com>
	 <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=jyzV6BwB6Lce0CCi+Z3MuwNsWLw2DQu8HBdm_J8kvArA@mail.gmail.com>
	 <1325757343.2415.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=hGnnuXf+cETy9fAeu+aACp2pfL3XfBS_jL_mk38fj4yQ@mail.gmail.com>
	 <1325757891.2415.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F05EECE.1000708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Michel Hautbois <jhautbois@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44254 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab2AESx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:53:27 -0500
Received: by wgbdr13 with SMTP id dr13so956700wgb.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 10:53:26 -0800 (PST)
In-Reply-To: <4F05EECE.1000708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 10:41 -0800, Rick Jones a =C3=A9crit :

> Why?  A netperf UDP_STREAM test is "purely" unidirectional (*).  I=20
> suspect the numbers look funny thanks to the 32-bit compilation bugs=20
> (format statement issues).

Unidirectional, but the receiver must send some status notifications ?

My reasonning (before you explained the compat problem between sender
and receiver) was that since we flooded the link, we were blocking
output from receiver (because of collisions), and=20
