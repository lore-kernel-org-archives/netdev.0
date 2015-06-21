From: David Miller <davem@davemloft.net>
Subject: Re: [RESUBMIT Patch 1/1] net: replace if()/BUG with BUG_ON
Date: Sun, 21 Jun 2015 09:55:17 -0700 (PDT)
Message-ID: <20150621.095517.1714979384853036107.davem@davemloft.net>
References: <CAH6sp9M=DABEgO2yS+cSSBfNJiwP6wxecWVtMTpb9P_rrcadCw@mail.gmail.com>
	<55812F32.5030306@gmail.com>
	<CAH6sp9PzTkNd88+ExRX1FTNNC=wC+jjOdL5urmtoyc5iz-pZTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: al.drozdov@gmail.com, maninder1.s@samsung.com, willemb@google.com,
	dborkman@redhat.com, viro@zeniv.linux.org.uk,
	eyal.birger@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pankaj.m@samsung.com
To: fransklaver@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAH6sp9PzTkNd88+ExRX1FTNNC=wC+jjOdL5urmtoyc5iz-pZTQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frans Klaver <fransklaver@gmail.com>
Date: Wed, 17 Jun 2015 10:30:18 +0200

> Ah, that explains something. If retire timer is not going to be needed
> for tx, wouldn't it be better to remove the whole tx_ring handling
> from this function altogether, rather than changing the BUG()?

Agreed.
