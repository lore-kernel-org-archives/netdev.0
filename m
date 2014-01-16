From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/2] reciprocal_divide: correction/update of the algorithm
Date: Thu, 16 Jan 2014 18:24:06 +0100
Message-ID: <20140116172406.GA17529@order.stressinduktion.org>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com> <1389828228-30312-3-git-send-email-dborkman@redhat.com> <alpine.DEB.2.10.1401161036110.29778@nuc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Austin S Hemmelgarn <ahferroin7@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Matt Mackall <mpm@selenic.com>,
	Pekka Enberg <penberg@kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1401161036110.29778@nuc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 16, 2014 at 10:37:37AM -0600, Christoph Lameter wrote:
> On Thu, 16 Jan 2014, Daniel Borkmann wrote:
> 
> > - * or else the performance is slower than a normal divide.
> > - */
> > -extern u32 reciprocal_value(u32 B);
> > +struct reciprocal_value {
> > +	u32 m;
> > +	u8 sh1, sh2;
> > +};
> >
> > +#define RECIPROCAL_VALUE_RESULT_TO_ZERO ((struct reciprocal_value){.sh1 = 32})
> >
> > -static inline u32 reciprocal_divide(u32 A, u32 R)
> > +struct reciprocal_value reciprocal_value(u32 d);
> 
> A function that returns a struct? That works? Which gcc versions support
> it?

Sure, that works and I actually like it. This is supported by the c standard,
but please don't ask me since which one. ;)

Greetings,

  Hannes
