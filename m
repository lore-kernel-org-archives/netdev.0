From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v2)
Date: Mon, 27 Oct 2008 10:53:30 -0400
Message-ID: <8bd0f97a0810270753m740a2295i492532f055f13b17@mail.gmail.com>
References: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 27, 2008 at 06:53, Paulius Zaleckas wrote:
> +       new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);

oh, and this should be kcalloc()
-mike
