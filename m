From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: extending feature word.
Date: Tue, 5 Apr 2011 13:30:07 +0200
Message-ID: <20110405113007.GA21358@rere.qmqm.pl>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com> <20110402124207.GB3147@rere.qmqm.pl> <BANLkTi=hCqT5BPe926N36omObpYvMcNtjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:44243 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183Ab1DELaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:30:09 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=hCqT5BPe926N36omObpYvMcNtjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 02, 2011 at 08:09:14PM -0700, Mahesh Bandewar wrote:
> On Sat, Apr 2, 2011 at 5:42 AM, Micha=B3 Miros=B3aw <mirq-linux@rere.=
qmqm.pl> wrote:
> > On Fri, Apr 01, 2011 at 07:07:05PM -0700, Mahesh Bandewar wrote:
> > If you want to split the work, it would be clearer to first convert
> > hw_features and wanted_features (with all the core code touching it=
 -
> > this is the easy part), then vlan_features (this includes drivers'
> > and VLAN code) and then features (it's all over).
> I like the idea of splitting but it will be only useful when all of i=
t
> is done and not partially, isn't it? Or am I missing something?

Since this is a big change, when split it might be easier to follow.
OTOH, with your idea of macro it might be easier to do incremental
changes (I think this will be a lot of work for no gain in this case).

Best Regards,
Micha=B3 Miros=B3aw
