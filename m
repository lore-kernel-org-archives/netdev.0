From: srinivas kandagatla <srinivas.kandagatla@st.com>
Subject: Re: stmmac-socfpga breakage in arm-soc
Date: Mon, 24 Mar 2014 09:15:39 +0000
Message-ID: <532FF7BB.5020003@st.com>
References: <201403191333.01095.arnd@arndb.de> <4337501.shzGE38xmF@wuerfel>
 <5329A7A1.20606@gmail.com> <4171731.dt8xNWCpb2@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Hans de Goede <hdegoede@redhat.com>,
 arm@kernel.org, linux-arm-kernel@lists.infradead.org,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 "David S.  Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@altera.com>
To: Arnd Bergmann <arnd@arndb.de>, Dinh Nguyen <dinh.linux@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4171731.dt8xNWCpb2@wuerfel>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 19/03/14 15:07, Arnd Bergmann wrote:
> Ok, so the two of you basically moved in opposite directions where
> Srinivas started out with the method you ended up with and vice versa.
Yes thats correct, While adding dwmac-sunxi.c we decided to go with
callback methods given its flexibility for calling at runtime(example:
when link speed changes).


--srini
