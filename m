From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: QRTR merge conflict resolution (was: Re: linux-next: build failure
 after merge of the net-next tree)
Date: Fri, 13 May 2016 15:19:09 -0700
Message-ID: <20160513221909.GC1256@tuxbot>
References: <20160510112905.5bffcad8@canb.auug.org.au>
 <20160510183934.GJ1256@tuxbot>
 <2606282.lG9qK7uBW0@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andy Gross <andy.gross@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	Olof Johansson <olof@lixom.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2606282.lG9qK7uBW0@wuerfel>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri 13 May 14:01 PDT 2016, Arnd Bergmann wrote:

> On Tuesday 10 May 2016 11:39:34 Bjorn Andersson wrote:
[..]
> > I assume we could have the QRTR go through Andy and arm-soc, with
> > David's approval and this fix squashed in. But we're running rather late
> > in this cycle, perhaps we should just back the QRTR patches out and I
> > can respin and resend them after the merge window (for v4.8 instead)?
> 
> I'd suggest you do a merge of next-next with the qcom/soc-2 branch that
> we have in arm-soc and resolve the conflict in the merge, then send
> a pull request with the merge to davem.
> 

Hi David,

In case you missed this thread, linux-next highlighted an upcoming merge
conflict between the net-next and one of the branches included in the
arm-soc trees.

I have prepared the merge of net-next and the conflicting tag from the
Qualcomm SOC, please include this in your pull towards Linus to avoid
the merge conflict.

Regards,
Bjorn

The following changes since commit ed7cbbce544856b20e5811de373cf92e92499771:

  udp: Resolve NULL pointer dereference over flow-based vxlan device (2016-05-13 01:56:14 -0400)

are available in the git repository at:

  git://github.com/andersson/kernel tags/net-next-qcom-soc-4.7-2-merge

for you to fetch changes up to f79a917e69e1f5cd86e864b67f06147f1b0340f4:

  Merge tag 'qcom-soc-for-4.7-2' into net-next (2016-05-13 14:42:23 -0700)

----------------------------------------------------------------
Merge tag 'qcom-soc-for-4.7-2' into net-next

This merges the Qualcomm SOC tree with the net-next, solving the
merge conflict in the SMD API between the two.

----------------------------------------------------------------
Andy Gross (1):
      Merge tag 'qcom-soc-for-4.7' into soc-for-4.7-p2

Bjorn Andersson (9):
      soc: qcom: smem_state: Add stubs for disabled smem_state
      soc: qcom: smd: Introduce callback setter
      soc: qcom: smd: Split discovery and state change work
      soc: qcom: smd: Refactor channel open and close handling
      soc: qcom: smd: Support multiple channels per sdev
      soc: qcom: smd: Support opening additional channels
      soc: qcom: smem: Use write-combine remap for SMEM
      soc: qcom: smd: Make callback pass channel reference
      Merge tag 'qcom-soc-for-4.7-2' into net-next

Lina Iyer (1):
      drivers: qcom: spm: avoid module usage in non-modular SPM driver

Srinivas Kandagatla (2):
      MAINTAINERS: add qcom i2c and spi drivers to list
      MAINTAINERS: add qcom clocks to the maintainers list

 MAINTAINERS                         |   3 +
 drivers/soc/qcom/smd-rpm.c          |   9 +-
 drivers/soc/qcom/smd.c              | 247 +++++++++++++++++++++++++++---------
 drivers/soc/qcom/smem.c             |   3 +-
 drivers/soc/qcom/spm.c              |   8 +-
 drivers/soc/qcom/wcnss_ctrl.c       |   8 +-
 include/linux/soc/qcom/smd.h        |  33 ++++-
 include/linux/soc/qcom/smem_state.h |  35 +++++
 net/qrtr/smd.c                      |   9 +-
 9 files changed, 278 insertions(+), 77 deletions(-)

> Alternatively, in case Linus merges net-next before we get that fix
> in, I could send Stephen's fix to Linus along with the pull requests.
> 
> 	Arnd
