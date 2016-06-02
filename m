From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: ath9k gpio request
Date: Thu, 02 Jun 2016 17:09:16 +0530
Message-ID: <57501AE4.7080104@gmail.com>
References: <20160530132225.4d297678@canb.auug.org.au>	<574C4851.9090201@gmail.com> <87fusy3cqx.fsf_-_@kamboji.qca.qualcomm.com>,<574D3EAA.3060102@gmail.com> <1464764036580.70506@qti.qualcomm.com> <574EC331.1080901@gmail.com>,<574ED297.4080004@gmail.com> <1464854569880.79341@qti.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	ath9k-devel <ath9k-devel@qca.qualcomm.com>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Miaoqing Pan <miaoqing@codeaurora.org>
To: "Pan, Miaoqing" <miaoqing@qti.qualcomm.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464854569880.79341@qti.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 02 June 2016 01:32 PM, Pan, Miaoqing wrote:
> Seems there are something wrong in the datasheet,  try
>
> --- a/drivers/net/wireless/ath/ath9k/reg.h
> +++ b/drivers/net/wireless/ath/ath9k/reg.h
> @@ -1122,8 +1122,8 @@ enum {
>   #define AR9300_NUM_GPIO                          16
>   #define AR9330_NUM_GPIO                                 16
>   #define AR9340_NUM_GPIO                                 23
> -#define AR9462_NUM_GPIO                                 10
> -#define AR9485_NUM_GPIO                                 12
> +#define AR9462_NUM_GPIO                                 14
> +#define AR9485_NUM_GPIO                                 11
>   #define AR9531_NUM_GPIO                                 18
>   #define AR9550_NUM_GPIO                                 24
>   #define AR9561_NUM_GPIO                                 23
> @@ -1139,8 +1139,8 @@ enum {
>   #define AR9300_GPIO_MASK                        0x0000F4FF
>   #define AR9330_GPIO_MASK                        0x0000F4FF
>   #define AR9340_GPIO_MASK                        0x0000000F
> -#define AR9462_GPIO_MASK                        0x000003FF
> -#define AR9485_GPIO_MASK                        0x00000FFF
> +#define AR9462_GPIO_MASK                        0x00003FFF
> +#define AR9485_GPIO_MASK                        0x000007FF
>   #define AR9531_GPIO_MASK                        0x0000000F
>   #define AR9550_GPIO_MASK                        0x0000000F
>   #define AR9561_GPIO_MASK                        0x0000000F

solves the problem.

Tested-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>

Regards
Sudip
