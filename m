From: Fabio Estevam <festevam@gmail.com>
Subject: Re: fec_main: context imbalance in 'fec_set_features'
Date: Thu, 9 Oct 2014 08:20:20 -0300
Message-ID: <CAOMZO5A_=o-J_ZhQPOaWcErc6ExUKk_-9MtSUY5MwGwm4Uc0-w@mail.gmail.com>
References: <CAOMZO5CJKp7+d8EPRZdr-3Bd9UxVU8fxLybFZ4uLn+cUQjPH8w@mail.gmail.com>
	<f5e97105d948410d8346ea6f0bc0d79e@BY2PR03MB377.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sparse@vger.kernel.org" <linux-sparse@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <linux-sparse-owner@vger.kernel.org>
In-Reply-To: <f5e97105d948410d8346ea6f0bc0d79e@BY2PR03MB377.namprd03.prod.outlook.com>
Sender: linux-sparse-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fugang,

On Thu, Oct 9, 2014 at 6:55 AM, fugang.duan@freescale.com
<fugang.duan@freescale.com> wrote:

> I run sparse and cannot get any warning.

Try it on linux-next with the following command:

make -j4 C=1  2>fect.txt drivers/net/ethernet/freescale/fec_main.o

cat v6.txt
drivers/net/ethernet/freescale/fec_main.c:2916:12: warning: context
imbalance in 'fec_set_features' - different lock contexts for basic
block
