From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] network configs: disconnect network options from drivers
Date: Tue, 5 Apr 2005 10:42:25 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504051033310.5053@localhost.localdomain>
References: <20050330234709.1868eee5.randy.dunlap@verizon.net>
 <20050331185226.GA8146@mars.ravnborg.org> <424C5745.7020501@osdl.org>
 <20050331203010.GA8034@mars.ravnborg.org> <4250B4C5.2000200@osdl.org>
 <20050404195051.GA12364@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, ioe-lkml@axxeo.de, matthew@wil.cx,
        lkml <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        hadi@cyberus.ca, cfriesen@nortel.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: Sam Ravnborg <sam@ravnborg.org>
In-Reply-To: <20050404195051.GA12364@mars.ravnborg.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Apr 2005, Sam Ravnborg wrote:

>
> Only bit that I am worried about is the statement in SCTP:
> 	depends on IPV6 || IPV6=n
>
> That looked like a noop to me. It had the sideeffect that SCTP
> menu entries where idented an extra level which was not desireable
> with currect layout.
>

No. This is not a noop. This is required to restrict SCTP configured as
static when IPV6 is configured as module.

Thanks
Sridhar
