From: jamal <hadi@cyberus.ca>
Subject: Re: Fw: hfsc and huge set of rules
Date: 30 Jul 2004 16:38:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091219916.1029.496.camel@jzny.localdomain>
References: <20040729211844.61e8d328.davem@redhat.com>
	 <410A2449.3020701@trash.net>  <20040730110815.GA7812@krezus.e-wro.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@redhat.com>,
        devik@cdi.cz, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>
In-Reply-To: <20040730110815.GA7812@krezus.e-wro.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tomasz,
Have you verified that this happens on other Linux versions
like earlier 2.4.x (2.4.21 for example)?
Also can you try just deleting the filters first and see what happens?
i.e something like:

filter add dev e0.931 protocol ip parent 1:101 pref 5
filter del dev e0.932 protocol ip parent 1:101 pref 5
..

delete them as specified above because that nips them at the
prio level.

BTW, since you are one of the few people i have seen use clever
hashing tricks with u32, could you test out u32 in 2.6.8-rc2 and
make sure it doesnt break anything? There is a bug fix that deals with 
selecting hash buckets.

cheers,
jamal
