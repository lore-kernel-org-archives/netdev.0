From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Sun, 30 Mar 2008 11:00:10 +0200
Message-ID: <47EF569A.1070400@free.fr>
References: <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local> <20080328120721.GA11060@ami.dom.local> <47EE3040.3050208@free.fr> <20080329122452.GB3407@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:45659 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbYC3JAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Mar 2008 05:00:13 -0400
In-Reply-To: <20080329122452.GB3407@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek,

I enlarged grep filter in order to grab AX.25 data that might be 
interesting too.

And this is the result :

# cat /var/log/kernel/info.log | grep AX...
Mar 30 10:19:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c74322e0
Mar 30 10:19:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c74322e0
Mar 30 10:19:13 f6bvp-9 kernel: AX25: ax25_frames_acked, 59, c2aa4130, 
c74322e0, 6b6b6b6b, 00000000, 00000000
Mar 30 10:19:59 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e7a70, c74322e0
Mar 30 10:19:59 f6bvp-9 kernel: AX25- ax25_release, 959, c14e7a70, c74322e0
Mar 30 10:20:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e7a70, c74322e0
Mar 30 10:20:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e7a70, c74322e0
Mar 30 10:20:59 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c74322e0
Mar 30 10:20:59 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c74322e0
Mar 30 10:21:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c74322e0
Mar 30 10:21:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c74322e0
Mar 30 10:21:59 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c74322e0
Mar 30 10:21:59 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c74322e0
Mar 30 10:22:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c74322e0
Mar 30 10:22:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c74322e0
Mar 30 10:22:37 f6bvp-9 kernel: AX25; ax25_make_new, 943, c14e7a70, c51ad820
Mar 30 10:22:37 f6bvp-9 kernel: AX25= ax25_accept, 1386, c14e7a70, 
c51ad820, c74322e0
Mar 30 10:22:38 f6bvp-9 kernel: AX.25: sendto: Addresses built.
Mar 30 10:22:38 f6bvp-9 kernel: AX.25: sendto: building packet.
Mar 30 10:22:38 f6bvp-9 kernel: AX.25: Appending user data
Mar 30 10:22:38 f6bvp-9 kernel: AX.25: Transmitting buffer
Mar 30 10:22:39 f6bvp-9 kernel: AX.25: sendto: Addresses built.
Mar 30 10:22:39 f6bvp-9 kernel: AX.25: sendto: building packet.
Mar 30 10:22:39 f6bvp-9 kernel: AX.25: Appending user data
Mar 30 10:22:39 f6bvp-9 kernel: AX.25: Transmitting buffer
Mar 30 10:22:39 f6bvp-9 kernel: AX.25: sendto: Addresses built.
Mar 30 10:22:39 f6bvp-9 kernel: AX.25: sendto: building packet.
Mar 30 10:22:39 f6bvp-9 kernel: AX.25: Appending user data
Mar 30 10:22:39 f6bvp-9 kernel: AX.25: Transmitting buffer
Mar 30 10:22:48 f6bvp-9 kernel: AX25: ax25_frames_acked, 59, c0f72290, 
c744a580, 6b6b6b6b, 00000000, 00000000
Mar 30 10:22:59 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e7658, c744a580
Mar 30 10:22:59 f6bvp-9 kernel: AX25- ax25_release, 959, c14e7658, c744a580
Mar 30 10:23:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e7658, c744a580
Mar 30 10:23:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e7658, c744a580
Mar 30 10:23:59 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6a10, c744a580
Mar 30 10:24:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6a10, c744a580
Mar 30 10:24:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6a10, c744a580
Mar 30 10:24:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6a10, c744a580
Mar 30 10:24:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e7658, c744a580
Mar 30 10:24:53 f6bvp-9 kernel: AX25- ax25_release, 959, c14e7658, c744a580
Mar 30 10:24:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e7658, c744a580
Mar 30 10:24:53 f6bvp-9 kernel: AX25- ax25_release, 959, c14e7658, c744a580
Mar 30 10:25:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e7658, c744a580
Mar 30 10:25:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e7658, c744a580
Mar 30 10:25:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e7658, c744a580
Mar 30 10:25:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e7658, c744a580
Mar 30 10:26:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c5afc8b0, c744a580
Mar 30 10:26:00 f6bvp-9 kernel: AX25- ax25_release, 959, c5afc8b0, c744a580
Mar 30 10:26:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c5afc8b0, c744a580
Mar 30 10:26:00 f6bvp-9 kernel: AX25- ax25_release, 959, c5afc8b0, c744a580
Mar 30 10:27:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c744a580
Mar 30 10:27:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c744a580
Mar 30 10:27:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c744a580
Mar 30 10:27:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c744a580
Mar 30 10:28:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6a10, c744a580
Mar 30 10:28:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6a10, c744a580
Mar 30 10:28:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6a10, c744a580
Mar 30 10:28:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6a10, c744a580
Mar 30 10:29:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c744a580
Mar 30 10:29:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c744a580
Mar 30 10:29:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c744a580
Mar 30 10:29:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c744a580
Mar 30 10:30:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6e28, c77bd040
Mar 30 10:30:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6e28, c77bd040
Mar 30 10:30:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c5afc8b0, c7527040
Mar 30 10:30:00 f6bvp-9 kernel: AX25- ax25_release, 959, c5afc8b0, c7527040
Mar 30 10:31:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6a10, c744a580
Mar 30 10:31:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6a10, c744a580
Mar 30 10:31:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c14e6a10, c744a580
Mar 30 10:31:00 f6bvp-9 kernel: AX25- ax25_release, 959, c14e6a10, c744a580
Mar 30 10:31:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c5afc8b0, c744a580
Mar 30 10:31:53 f6bvp-9 kernel: AX25- ax25_release, 959, c5afc8b0, c744a580
Mar 30 10:31:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c5afc8b0, c744a580
Mar 30 10:31:53 f6bvp-9 kernel: AX25- ax25_release, 959, c5afc8b0, c744a580
Mar 30 10:32:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c5afc8b0, c744a580
Mar 30 10:32:00 f6bvp-9 kernel: AX25- ax25_release, 959, c5afc8b0, c744a580
Mar 30 10:32:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c5afc8b0, c744a580
Mar 30 10:32:00 f6bvp-9 kernel: AX25- ax25_release, 959, c5afc8b0, c744a580
Mar 30 10:32:38 f6bvp-9 kernel: AX.25: sendto: Addresses built.
Mar 30 10:32:38 f6bvp-9 kernel: AX.25: sendto: building packet.
Mar 30 10:32:38 f6bvp-9 kernel: AX.25: Appending user data
Mar 30 10:32:38 f6bvp-9 kernel: AX.25: Transmitting buffer
Mar 30 10:32:39 f6bvp-9 kernel: AX25- ax25_release, 959, c14e7a70, c74322e0
Mar 30 10:32:52 f6bvp-9 kernel: AX25: ax25_frames_acked, 59, c0f72aa8, 
c74322e0, 6b6b6b6b, 00000000, 00000000
Mar 30 10:32:52 f6bvp-9 kernel: AX25: ax25_frames_acked, 59, c0f732c0, 
c779cd60, 6b6b6b6b, 00000000, 00000000
Mar 30 10:33:00 f6bvp-9 kernel: AX25+ ax25_create, 866, c5afc8b0, c779cd60
Mar 30 10:33:00 f6bvp-9 kernel: AX25- ax25_release, 959, c5afc8b0, c779cd60

#

Regards,

Bernard
