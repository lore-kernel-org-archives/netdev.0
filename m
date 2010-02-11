From: Steve.Glendinning@smsc.com
Subject: Re: smsc911x suspend/resume
Date: Thu, 11 Feb 2010 18:26:32 +0000
Message-ID: <OFB9598254.A94CFB16-ON802576C5.004BB8B6-802576C7.00655296@smsc.com>
References: <20100208144951.GF28972@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel-bounces@lists.infradead.org,
	Ian.Saturley@smsc.com, LAKML <linux-arm-kernel@lists.infradead.org>,
	Mike Rapoport <mike@compulab.co.il>
To: Daniel Mack <daniel@caiaq.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100208144951.GF28972@buzzloop.caiaq.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> Hmm, be careful about switching off power supplies that aren't supposed
> to be switched off while others are still powered. You can easily
> destroy hardware with that. Depending on how things are wired up
> internally, voltages can leak from one unit block to the other. Maybe
> Steve can can give a statement from official SMSC source about whether
> it is safe to switch off VDD33A in this case.

I've checked with the chip architects, no power planes should be 
externally
switched off in any suspend mode.

Steve
