From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: linux-next: manual merge of the net tree with the i2c tree
Date: Tue, 10 Nov 2009 15:10:27 +0000
Message-ID: <1257865827.2834.12.camel@achroite.uk.solarflarecom.com>
References: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
	 <20091110124231.66141a0f@hyperion.delvare>
	 <1257859379.2834.2.camel@achroite.uk.solarflarecom.com>
	 <20091110160246.506b7789@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mika Kuoppala <mika.kuoppala@nokia.com>
To: Jean Delvare <khali@linux-fr.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091110160246.506b7789@hyperion.delvare>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-10 at 16:02 +0100, Jean Delvare wrote:
> On Tue, 10 Nov 2009 13:22:58 +0000, Ben Hutchings wrote:
> > On Tue, 2009-11-10 at 12:42 +0100, Jean Delvare wrote:
> > > Ben, you can adjust your own patches to make use of this API instead of
> > > accessing the i2c_adapter mutex directly. That way, you are no longer
> > > dependent of implementation changes, and this should solve the conflict.
> > > 
> > > Stephen, you can then drop your fixup patch.
> > 
> > I don't think so, since the conflict resulted from joining two files
> > including sfe4001.c in net-next-2.6.
> 
> My patch series no longer touches sfe4001.c, so how would the conflict
> remain?

Because your patch to introduce i2c_{lock,unlock}_adapter() are not in
net-next-2.6 yet.

David, you might want to pull from Linus and resolve this, giving
Stephen a break.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
