From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [patch 10/13] net/socket.c::sys_bind() cleanup.
Date: Wed, 24 Nov 2004 14:03:17 -0800
Message-ID: <OFF45FF067.1B428792-ON88256F56.0078D794-88256F56.007926F9@us.ibm.com>
References: <41A4688E.80908@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: akpm@osdl.org, "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <41A4688E.80908@conectiva.com.br>
To: Luiz Fernando Capitulino <lcapitulino@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's just a style issue, so maybe you'll disagree, but I prefer:

        if (!sock)
                return err;

to your

        if (!sock)
                goto out;
...
out:
        return err;

        I think "return err" is more readable than "goto out/return err" 
for
that path and having another "return err" for the out-with-put case isn't 
a
terrible thing.

                                +-DLS
