From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 0/2] ethernet: intel: Support Hyper-V hosts
Date: Thu, 14 Apr 2016 19:21:00 -0700
Message-ID: <CAL3LdT4c5nhxeOrWcCPfGXAJVx2iWyjjMik6aaF3V-STBRXo0A@mail.gmail.com>
References: <1460678121-30308-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, intel-wired-lan@linuxonhyperv.com,
 netdev <netdev@vger.kernel.org>, jasowang@redhat.com,
 LKML <linux-kernel@vger.kernel.org>, jackm@mellanox.com, yevgenyp@mellanox.com,
 "Ronciak, John" <john.ronciak@intel.com>, eli@mellanox.com, apw@canonical.com,
 devel@linuxdriverproject.org, David Miller <davem@davemloft.net>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1460678121-30308-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2016 at 4:55 PM, K. Y. Srinivasan <kys@microsoft.com> wrote:
> Make adjustments to the Intel 10G VF driver to support
> running on Hyper-V hosts.
>
> K. Y. Srinivasan (2):
>   ethernet: intel: Add the device ID's presented while running on
>     Hyper-V
>   intel: ixgbevf: Support Windows hosts (Hyper-V)
>
>  drivers/net/ethernet/intel/ixgbevf/defines.h      |    5 +
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   11 ++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   56 ++++++---
>  drivers/net/ethernet/intel/ixgbevf/mbx.c          |   12 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           |  138 +++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +
>  6 files changed, 206 insertions(+), 18 deletions(-)

Don't know how you butchered the mailing list address, but you did not
send this series to intel-wired-lan@lists.osuosl.org mailing list.
Please address the requested changes that Mark suggested and resubmit
to the correct mailing list please.
