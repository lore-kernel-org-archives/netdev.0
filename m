From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 5/8] staging: et131x: Remove unnecessary i2c_wack variable
Date: Wed, 20 Aug 2014 19:22:54 -0300
Message-ID: <CAOMZO5Du34=jpr5B_fHGZ+D_jNR0VSDy2BiO6jj8QByh7V40RQ@mail.gmail.com>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
 <1408573078-9320-6-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linux-kernel <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mark Einon <mark.einon@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408573078-9320-6-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 20, 2014 at 7:17 PM, Mark Einon <mark.einon@gmail.com> wrote:

>                         do {
>                                 pci_read_config_dword(pdev,
> -                                       LBCIF_DATA_REGISTER, &val);
> +                                                     LBCIF_DATA_REGISTER,
> +                                                     &val);

This seems to be an unrelated change.
