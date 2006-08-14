From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 1/6] ehea: interface to network stack
Date: Tue, 15 Aug 2006 00:38:42 +1000
Message-ID: <20060814143842.GM479@krispykreme>
References: <44D99EFC.3000105@de.ibm.com> <20060811205624.GE479@krispykreme> <20060814112656.GC10164@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932440AbWHNOkr@vger.kernel.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Content-Disposition: inline
In-Reply-To: <20060814112656.GC10164@wohnheim.fh-wedel.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Is a conditional cheaper than a divide?  In case of a misprediction I
> would assume it to be significantly slower and I don't know the ratio
> of mispredictions for this branch.

A quick scan of the web shows 40 cycles for athlon64 idiv, and its
similarly slow on many other cpus. Even assuming you mispredict every
branch its going to be a win.

Anton
