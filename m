From: "David Schwartz" <davids@webmaster.com>
Subject: RE: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Thu, 22 Nov 2007 22:06:35 -0800
Message-ID: <MDEHLPKNGKAHNMBLJOLKIEFLIGAC.davids@webmaster.com>
References: <20071122.171306.166854987.davem@davemloft.net>
Reply-To: davids@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755423AbXKWGHy@vger.kernel.org>
In-Reply-To: <20071122.171306.166854987.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Regardless of whatever verifications your application is doing
> on the data, it is not checksumming the ports and that's what
> the pseudo-header is helping with.

So what? We are in the case where the data has already gotten to him. If it
got to him in error, he'll reject it anyway. The receive checksum check will
only reject packets that he would reject anyway. That makes it needless.

Of course, if the check is nearly free, there's no potential win, so no
point in bothering.

DS
