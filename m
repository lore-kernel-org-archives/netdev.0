From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] meta ematch
Date: 16 Jan 2005 12:24:12 -0500
Message-ID: <1105896252.1097.724.camel@jzny.localdomain>
References: <20050106194102.GW26856@postel.suug.ch>
	 <1105105511.1046.77.camel@jzny.localdomain>
	 <20050108145457.GZ26856@postel.suug.ch>
	 <1105363582.1041.162.camel@jzny.localdomain>
	 <20050110211747.GA26856@postel.suug.ch>
	 <1105394738.1085.63.camel@jzny.localdomain>
	 <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net>
	 <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net>
	 <20050114151407.GR26856@postel.suug.ch>
	 <1105891871.1097.647.camel@jzny.localdomain>  <41EA9720.7070503@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41EA9720.7070503@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-16 at 11:32, Patrick McHardy wrote:
> jamal wrote:
> 
[..]
> >BTW, it would probably be useful to return some mnemonic instead of 0.

> Returning 0 for success and negative error codes is perfectly fine as long
> as you don't need any magic numbers (1, 2, ..).

[..]

> >>+static int meta_int_compare(struct meta_obj *a, struct meta_obj *b)
> >>+{
> >>+	/* Let gcc optimize it, the unlikely is not really based on
> >>+	 * some numbers but jump free code for missmatches seems
> >>+	 * more logical.
> >>+	 */
> >>+	if (unlikely(a == b))
> >>+		return 0;
> >>+	else if (a < b)
> >>+		return -1;
> >>+	else
> >>+		return 1;
> >>+}
> >>    
> >>
> >
> >Would be very useful to return mnemonics for readability.
> >  
> >
> Same as for above, everyone knows what to expect from a *_compare function.
> Returning stuff like CMP_LT, CMP_BT, .. is just ugly.

I am not sure i remember whether -1 or 1 is the LT even though i have
used strcmp for years ;-> Actually i try hard not to have my brain
remember. In the case of the .get function above, i may agree with you
that returning MATCH_SUCEEDED may be a little overkill.

cheers,
jamal
