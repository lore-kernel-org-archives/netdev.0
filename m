From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH V5 2/11] IB/ipoib: Notify the world before
	doing unregister
Date: Thu, 20 Sep 2007 09:20:57 -0700
Message-ID: <adaabrhgvfa.fsf@cisco.com>
References: <46F27692.3070404@voltaire.com> <46F2784C.9070806@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Moni Shoua <monis@voltaire.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46F2784C.9070806@voltaire.com> (Moni Shoua's message of "Thu,
	20 Sep 2007 16:40:28 +0300")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > +		ipoib_slave_detach(cpriv->dev);
 >  		unregister_netdev(cpriv->dev);

Maybe you already answered this before, but I'm still not clear why
this notifier call can't just be added to the start of
unregister_netdevice(), so we can avoid having driver needing to know
anything about bonding internals?

 - R.
