From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Tue, 21 Jun 2011 13:02:48 -0600
Message-ID: <BANLkTikHTSgowpUhMCcOMXk_oQd4Ue7S3Q@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
	<20110618161934.GH8195@ponder.secretlab.ca>
	<20110619073000.GA23171@S2100-06.ap.freescale.net>
	<20110621135558.GB9228@S2101-09.ap.freescale.net>
	<4E00E3D2.6050602@firmworks.com>
	<BANLkTiny9xDwiUww9Ys+jQZ0SHdQATABUA@mail.gmail.com>
	<20110621185356.GJ23234@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: patches@linaro.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	Shawn Guo <shawn.guo@freescale.com>, Mitch Bradley <wmb@firmworks.com>,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>, linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20110621185356.GJ23234@n2100.arm.linux.org.uk>
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

On Tue, Jun 21, 2011 at 12:53 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Tue, Jun 21, 2011 at 12:42:14PM -0600, Grant Likely wrote:
>> On Tue, Jun 21, 2011 at 12:32 PM, Mitch Bradley <wmb@firmworks.com> wrot=
e:
>> > I wonder if it makes sense to create a new device node "/linux-devices=
" to express a desired mapping from device nodes to /dev entries? =A0The pr=
operties could be the names of device special files and the values the corr=
esponding node phandles.
>>
>> I've been trying /really/ hard to avoid doing something like that
>> because a lot of the time the desired Linux dev name is a
>> implementation detail, and a potentially unstable one at that. =A0If
>> Linux requires certain devices to have certain names because that is
>> how it hooks up clocks
>
> As I keep on saying, we don't _have_ to have to match on device name.
> If DT can come up with a better way to bind a clock to a particular
> device/connection name then DT can provide its own clk_get()
> implementation which does that.

Sorry, I overstated the situation.  My point is only that I don't want
encode how Linux currently views the world into the DT, because
implementation details can and do change.

g.
