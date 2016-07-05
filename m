From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Mon, 04 Jul 2016 23:27:04 -0700 (PDT)
Message-ID: <20160704.232704.1161688488597729534.davem@davemloft.net>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
	<CO2PR03MB21823DBFD52A5CF4F96DB712BF390@CO2PR03MB2182.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com,
	vkuznets@redhat.com, cavery@redhat.com, kys@microsoft.com,
	haiyangz@microsoft.com, joe@perches.com, rolf.neugebauer@docker.com
To: decui@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR03MB21823DBFD52A5CF4F96DB712BF390@CO2PR03MB2182.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Tue, 5 Jul 2016 01:58:31 +0000

> Not sure if you had a chance to review this version.

Why me?

Other people have to review this too.

> Now I have a question: may I split the include/linux/socket.h change
> and ask you to pre-allocate the number for AF_HYPERV to allow
> backporting of Hyper-V Sockets to distro kernels, and to make sure
> that applications using the socket type will work with the backport
> as well as the upstream kernel?

Sorry, I'm not going to do this.

You cannot commit anything in userspace to this value anywhere
until it is accepted upstream.
