From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter
Date: Fri, 28 Jan 2005 02:35:42 +0100
Message-ID: <41F996EE.2030409@trash.net>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>	 <p73zn0ccaee.fsf@verdi.suse.de>	 <1105117559.11753.34.camel@baythorne.infradead.org>	 <20050107100017.454ddadc@dxpl.pdx.osdl.net>	 <1105133241.3375.16.camel@localhost.localdomain>	 <20050118135735.4b77d38d.davem@davemloft.net>	 <1106433059.4486.11.camel@localhost.localdomain>	 <1106436153.20995.42.camel@tux.rsn.bth.se>	 <1106484019.3376.5.camel@localhost.localdomain>	 <1106496509.1085.1.camel@tux.rsn.bth.se>	 <20050125220558.6e824f8a.davem@davemloft.net>	 <1106730510.4041.4.camel@localhost.localdomain>	 <41F82C6D.7020006@trash.net> <20050126231801.7bf90338.davem@davemloft.net>	 <41F929FA.3050800@trash.net> <20050127114726.2205b4ed.davem@davemloft.net>	 <41F96FA4.4000105@trash.net> <20050127152450.6daba4fa.davem@davemloft.net>	 <1106872169.18360.6.camel@localhost.localdomain>	 <20050127171023.2e8547e1.davem@davemloft
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, bdschuym@pandora.be,
        netdev@oss.sgi.com,
        Netfilter development mailing list <netfilter-devel@lists.netfilter.org>,
        snort2004@mail.ru, ak@suse.de, bridge@osdl.org, gandalf@wlug.westbo.se,
        dwmw2@infradead.org, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <1106875946.18360.29.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:

>On Thu, 2005-01-27 at 17:10 -0800, David S. Miller wrote:
>
>>In tree, yes.  But leaving the NF_HOOK()/NF_HOOK_THRESH() compat
>>macros in there for out-of-tree modules I feel is mandatory, it's
>>a major API change.
>>
>
>I'm not so sure.  The hook functions which are registered, sure (ie.
>keep the calling convention the same).  But do any external modules use
>NF_HOOK()?  That implies they're writing their own network stack for
>some protocol, which I would expect to be uncommon.
>
Freeswan comes to mind. But I guess one more #ifdef can't hurt :)

Regards
Patrick
