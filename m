From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 12:57:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306101658.h5AGwtsG008215@ginger.cmf.nrl.navy.mil>
References: <20030610.092748.115929981.davem@redhat.com>
Cc: hadi@shell.cyberus.ca, ralph+d@istop.com, xerox@foonet.net,
   sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-reply-to: Your message of "Tue, 10 Jun 2003 09:27:48 PDT."
             <20030610.092748.115929981.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030610.092748.115929981.davem@redhat.com>,"David S. Miller" write
s:
>Ok, time to deploy ATM everywhere to replace our IP routers :)
>Sorry Chas, I couldn't resist... :)

i see a lot of crying about the 'atm tax' but it seems to me that the 'ip tax'
is typically much steeper (except when you graph packet_count*packet_size
then you will see that the bulk of the data is carried by larger packets
were the tax isnt as high).  so for some applications, like voice, atm might
actually be a winner as far as the tax goes (as long as you arent doing
voice over ip over atm)

hosestly i needed real numbers to tune the atm driver on our linux-router.
i have two recv buffer pools--small and large (duh).  i needed an idea of what
to use for the small value.
