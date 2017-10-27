From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net-next v6 2/2] bridge: vlan: signal if
 anything changed on vlan add
Date: Sat, 28 Oct 2017 08:34:03 +0900
Message-ID: <01acc055-ad4e-c35b-e6b5-5f0493e9c5ac@gmail.com>
References: <1f6df7e3-cd05-9b96-9f45-49c433011ff2@cumulusnetworks.com>
	<1509099577-5959-1-git-send-email-nikolay@cumulusnetworks.com>
	<1509099577-5959-3-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	mrv@mojatatu.com, dsa@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1509099577-5959-3-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 17/10/27 (金) 19:19, Nikolay Aleksandrov wrote:
> Before this patch there was no way to tell if the vlan add operation
> actually changed anything, thus we would always generate a notification
> on adds. Let's make the notifications more precise and generate them
> only if anything changed, so use the new bool parameter to signal that the
> vlan was updated. We cannot return an error because there are valid use
> cases that will be broken (e.g. overlapping range add) and also we can't
> risk masking errors due to calls into drivers for vlan add which can
> potentially return anything.
>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Reviewed-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Toshiaki Makita
