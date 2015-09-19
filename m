From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [linux-next] oops in ip_route_input_noref
Date: Sat, 19 Sep 2015 08:34:02 -0600
Message-ID: <55FD725A.1080107@cumulusnetworks.com>
References: <20150916092447.GA945@swordfish>
 <CAOMZO5CTgq_Sd81=XWEHv5oe1WyVpaydNzUXz_EbY2BWR6xF7g@mail.gmail.com>
 <55F984EF.4040503@cumulusnetworks.com> <20150917085850.GA7953@ulmo>
 <20150918160607.574425f5e3b1f0afe29b7448@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam@gmail.com>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	richard.alpe@ericsson.com
To: Andrew Morton <akpm@linux-foundation.org>,
	Thierry Reding <thierry.reding@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150918160607.574425f5e3b1f0afe29b7448@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/18/15 5:06 PM, Andrew Morton wrote:
>
> I've been hitting this as well.  An oops on boot in
> ip_route_input_slow(), here:

Fixed in net-next. bde6f9ded1bd37ff27a042dcb968e104d92b02c1

David
