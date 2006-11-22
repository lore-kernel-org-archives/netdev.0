From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 14:46:44 +0100
Message-ID: <456454C4.5010803@fr.ibm.com>
References: <4563007B.9010202@fr.ibm.com> <4563046B.6040909@sw.ru>	<45633EDF.3050309@fr.ibm.com> <20061121181655.GA14656@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:48836 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1755875AbWKVNqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 08:46:53 -0500
To: Daniel Lezcano <dlezcano@fr.ibm.com>, Kirill Korotaev <dev@sw.ru>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Dmitry Mishin <dim@sw.ru>, netdev@vger.kernel.org
In-Reply-To: <20061121181655.GA14656@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> no problem here, but I think we will need another one,
> or some smart way to do the network isolation (layer 3)
> for the network namespace (as alternative to the layer 2
> approach) ...

My feeling (Dmitry and Daniel can correct me) is that it will be
addressed with an unshare-like flag : NETNS2 and NETNS3.
 
> as they are both complementary in some way, I'm not sure
> a single space will suffice ...

hmm, so you think there could be a 2 differents namespaces
for network to handle layer 2 or 3. Couldn't that be just a sub part
of net_namespace.

C.
