From: Jason Wang <jasowang@redhat.com>
Subject: Patches required for 3.9 stable
Date: Mon, 17 Jun 2013 15:58:59 +0800
Message-ID: <51BEC1C3.40109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, jwboyer@redhat.com
To: gregkh@linuxfoundation.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38179 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755089Ab3FQH7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 03:59:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg:

Please include the following commits into 3.9.y. Which fixes:

1) Crash when sending GSO packets from untrusted sources
9b4d669bc06c215d64f56f1eb0d4eb96e14d689d
38502af77e07b5d6650b9ff99a0b482d86366592
c1aad275b0293d2b1905ec95a945422262470684
f9ca8f74399f9195fd8e01f67a8424a8d33efa55
15e5a030716468dce4032fa0f398d840fa2756f6

2) Can't create a multiqueue tap
e8dbad66ef56074eadb41ed5998acd2320447018

All can be cheery-picked and I have tested them.

Thanks
