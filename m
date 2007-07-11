From: Clemens Brunner <clemens.brunner@tugraz.at>
Subject: Re: No network on Asus P5B (r8169)
Date: Wed, 11 Jul 2007 15:39:58 +0200
Message-ID: <200707111539.58711.clemens.brunner@tugraz.at>
References: <20070628234222.GA8180@electric-eye.fr.zoreil.com> <200707101845.24297.clemens.brunner@tugraz.at> <20070710222508.GD3436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay.tu-graz.ac.at ([129.27.2.202]:57777 "EHLO
	mailrelay.tugraz.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759978AbXGKNjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 09:39:54 -0400
In-Reply-To: <20070710222508.GD3436@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Does your setup exclude the "wake up" issue described in
> http://gentoo-wiki.com/HARDWARE_RTL8168 ?

You're right, that was the problem! With the "wake up on LAN" option enabled 
in Windows, networking is working perfectly in Linux (32 bit and 64 bit).

Which leaves only one question: Is it likely that this issue will be fixed 
anytime soon? In other words, will the Linux driver be able to enable the 
NIC?

Clemens
