From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] wireless: test sscanf return values
Date: Fri, 27 Feb 2015 04:36:19 -0800
Message-ID: <1425040579.2690.9.camel@perches.com>
References: <1425015791.2690.7.camel@perches.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAF0B29@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAF0B29@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-02-27 at 10:35 +0000, David Laight wrote:
> From: Joe Perches
> > At some point, it'd be good to make sscanf use __must_check
> > so make sure the net/ uses of sscanf use the return value.
> 
> Isn't it much safer to avoid sscanf() completely and use
> a different function for converting numerics?

It's generally better to use something other than sscanf.
That doesn't mean sscanf isn't useful.
