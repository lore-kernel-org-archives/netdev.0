From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: add ability to set a timestamp offset
Date: Tue, 22 Jan 2013 13:16:27 -0800
Message-ID: <50FF01AB.4050401@hp.com>
References: <1358887953-28665-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Dave Jones <davej@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358887953-28665-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/22/2013 12:52 PM, Andrey Vagin wrote:
> If a TCP socket will get live-migrated from one box to another the
> timestamps (which are typically ON) will get screwed up -- the new
> kernel will generate TS values that has nothing to do with what they
> were on dump. The solution is to yet again fix the kernel and put a
> "timestamp offset" on a socket.

Is there a chance a connection can be moved more than once within the 
"lifetime" of a given timestamp value?

rick jones
