From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: 3c59x
Date: Tue, 10 Jun 2003 13:39:15 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200306101741.h5AHf8sG008844@ginger.cmf.nrl.navy.mil>
References: <20030610.103111.26297722.davem@redhat.com>
Cc: jgarzik@pobox.com, ak@suse.de,
	bogdan.costescu@iwr.uni-heidelberg.de, hadi@shell.cyberus.ca,
	ralph+d@istop.com, xerox@foonet.net, sim@netnation.com,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Tue, 10 Jun 2003 10:31:11 PDT."
             <20030610.103111.26297722.davem@redhat.com>
List-Id: netdev.vger.kernel.org

>Function calls are actually more expensive, you eat an entry in
>the cpu's return address cache.

i was thinking you could do it higher up, like around the hard_start_xmit
level.  this would create a bit of replicated code, but you could abuse
the preprocessor a bit i imagine.
