From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: Re[4]: net_device + pci_dev question
Date: Mon, 28 Nov 2005 22:08:11 +0100
Message-ID: <527051512.20051128220811@gmail.com>
References: <2510370984.20051127205827@gmail.com>
 <1133126713.2853.45.camel@laptopd505.fenrus.org>
 <1653628458.20051128215644@gmail.com>
 <1133211819.2824.82.camel@laptopd505.fenrus.org>
Reply-To: Mateusz Berezecki <mateuszb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751276AbVK1VIV@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1133211819.2824.82.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Arjan,

On 28th november 2005 (22:03:38) you wrote:

> oh it's *your own* netdev...

Yes:-) Sorry for not being precise

> that makes things a lot easier ;)


> it's custom to have driver private data per net dev
> (see netdev_priv() to get it, alloc_etherdev() takes the size of it as
> argument). It's custom to make that private data a struct in which you
> can store the pci device pointer yourself, as well as any other per card
> data that you need to store


Ok, I will do it like that then. Thank you for the explanation on this
issue.

kind regards,
Mateusz Berezecki
