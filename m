From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: 3c59x
Date: Tue, 10 Jun 2003 13:29:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306101731.h5AHVlsG008694@ginger.cmf.nrl.navy.mil>
References: <20030610171617.GC1959@gtf.org>
Cc: "David S. Miller" <davem@redhat.com>, ak@suse.de,
   bogdan.costescu@iwr.uni-heidelberg.de, hadi@shell.cyberus.ca,
   ralph+d@istop.com, xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-reply-to: Your message of "Tue, 10 Jun 2003 13:16:17 EDT."
             <20030610171617.GC1959@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030610171617.GC1959@gtf.org>,Jeff Garzik writes:
>Making every IO a conditional branch?  Ug.

you could just test once during driver init and setup an indirection
to the appropriate function.  its a little better than test and branch.
