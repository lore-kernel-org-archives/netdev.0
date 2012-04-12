From: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Subject: Regression due to "ath9k: fix going to full-sleep on
	PS idle"
Date: Thu, 12 Apr 2012 10:37:44 +0530
Message-ID: <20358.25376.230264.236893@gargle.gargle.HOWL>
References: <CA+55aFxWD1bE0oiR4GpLP19MCm2CzwuApuYhcE_NF7bC+tFYjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "ath9k-devel@lists.ath9k.org" <ath9k-devel@venema.h4ckr.net>,
	KH <gregkh@linuxfoundation.org>,
	linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>, Greg@venema.h4ckr.net,
	Heinz Diehl <htd@fancy-poultry.org>,
	Network Development <netdev@vger.kernel.org>,
	akpm@linux-foundation.org, David Miller <davem@davemloft.net>,
	alan@lxorguk.ukuu.org.uk
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <CA+55aFxWD1bE0oiR4GpLP19MCm2CzwuApuYhcE_NF7bC+tFYjg@mail.gmail.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> You guys need to fix the subject line (like this), and make sure that
> the right people are cc'd. This is not a "stable" issue - stable
> cannot revert stuff that hasn't been reverted upstream.
> 
> So instead of stable and Greg, it should be netdev and Davem.
> 
> David/John: multiple people are complaining about that commit. It
> really should be reverted, or a fix found. It's broken.
> 
> I can do the revert, but it would be better coming from the networking people.

John has already reverted the commit:
http://git.kernel.org/?p=linux/kernel/git/linville/wireless.git;a=commit;h=011afa1ed8c408d694957d2474d89dc81a60b70c

Sujith
