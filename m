From: Malcolm Priestley <tvboxspy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] vt6656: [BUG] - Failed connection, incorrect endian. v2
Date: Wed, 29 Aug 2012 23:12:37 +0100
Message-ID: <1346278357.2177.7.camel@router7789>
References: <1346273644.2077.3.camel@router7789>
	 <503E8789.6050809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <503E8789.6050809-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-08-29 at 16:20 -0500, Larry Finger wrote:
> On 08/29/2012 03:54 PM, Malcolm Priestley wrote:
> >
> > This patch fixes a bug with driver failing to negotiate a connection.
> >
> > The bug was traced to commit
> > 203e4615ee9d9fa8d3506b9d0ef30095e4d5bc90
> > staging: vt6656: removed custom definitions of Ethernet packet types
> >
> > In that patch, definitions in include/linux/if_ether.h replaced ones
> > in tether.h which had both big and little endian definitions.
> >
> > include/linux/if_ether.h only refers to big endian values, cpu_to_be16
> > should be used for the correct endian architectures.
> >
> > checkpatch fixed version.
> >
> > Signed-off-by: Malcolm Priestley <tvboxspy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> Patches for staging drivers should be sent to gregkh-hQyY1W1yCW8ekmWlsbkhG5u6nac5fYnt@public.gmane.org He is 
> the one that handles them. In addition, the patch subject line usually has the 
> sequence "staging: vt6656: blabla" the way the faulty patch did.

Thanks

I have forwarded the patch.


Regards


Malcolm



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
