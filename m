From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: strange Mac OSX RST behavior
Date: Fri, 1 Jul 2016 19:16:09 +0100
Message-ID: <20160701191609.1fc1c045@lxorguk.ukuu.org.uk>
References: <1467385815-6357-1-git-send-email-jbaron@akamai.com>
	<5776A3A4.8000503@hpe.com>
	<5776A607.70800@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>
To: Jason Baron <jbaron@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5776A607.70800@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> yes, we do in fact see a POLLRDHUP from the FIN in this case and
> read of zero, but we still have more data to write to the socket, and
> b/c the RST is dropped here, the socket stays in TIME_WAIT until
> things eventually time out...

After the FIN when you send/retransmit your next segment do you then get
a valid RST back from the Mac end?

Alan
