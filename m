From: shemminger@osdl.org
Subject: Re: [Bridge] Re: [PATCH] (1/4) propgate bridge internal MTU changes
Date: Wed, 28 Jul 2004 22:10:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <33064.63.170.215.71.1091077856.squirrel@www.osdl.org>
References: <20040728153725.7ace281c@dell_ss3.pdx.osdl.net>
    <20040728191724.4afacdce.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>, netdev@oss.sgi.com,
        bridge@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040728191724.4afacdce.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>
> I assume these 4 patches are for 2.6.x?  I'll hit them tomorrow,
> regardless.
> _______________________________________________
> Bridge mailing list
> Bridge@lists.osdl.org
> http://lists.osdl.org/mailman/listinfo/bridge

There is one missing additional piece, the fdb RCU code needs
to use call_rcu().  Testing it now.
