From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] r8169: Randomise invalid MAC addresses
Date: Mon, 23 Jan 2012 21:29:14 +0000
Message-ID: <20120123212914.747c852f@pyramind.ukuu.org.uk>
References: <1327343540-30348-1-git-send-email-torne@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Torne (Richard Coles)" <torne@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327343540-30348-1-git-send-email-torne@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Jan 2012 18:32:20 +0000
"Torne (Richard Coles)" <torne@google.com> wrote:

> From: "Torne (Richard Coles)" <torne@google.com>
> 
> If the default MAC address stored in the card is invalid, replace it
> with a random address and complain about it.

See the discussion about the pch ethernet card. Detect the error and warn
about it, block opening it and let the user set it with ifconfig xx hw
aa:bb:cc:dd:ee:ff

Alan
