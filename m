From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Wed, 27 Oct 2004 21:42:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027214257.24637a9f.davem@davemloft.net>
References: <41797696.9070905@candelatech.com>
	<20041022214611.GA4948@electric-eye.fr.zoreil.com>
	<41798506.1030909@candelatech.com>
	<417D675F.3000909@candelatech.com>
	<417D929A.2090809@candelatech.com>
	<20041027164912.09cc63f8.davem@davemloft.net>
	<41804B35.1080306@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41804B35.1080306@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 18:28:21 -0700
Ben Greear <greearb@candelatech.com> wrote:

> > Also, what is up with the magic "23" constant in the get realdev
> > name function strncpy() call?
> 
> Well, the fields are 24-bytes long, as defined in the include/linux/if_vlan.h
> file.  I could change it to a #define and/or use sizeof if you prefer.

You could also use "sizeof(obj->member)".
