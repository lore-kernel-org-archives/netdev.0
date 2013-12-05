From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net/stable] br: fix use of ->rx_handler_data in
 code executed on non-rx_handler path
Date: Thu, 05 Dec 2013 07:19:18 -0800
Message-ID: <1386256758.30495.195.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386255025-23823-1-git-send-email-jiri@resnulli.us>
	<20131205145842.GD23147@redhat.com>
	<20131205150158.GA2626@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jtluka@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, edumazet@google.com,
	laine@redhat.com, zhiguohong@tencent.com, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20131205150158.GA2626@minipsycho.orion>
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

On Thu, 2013-12-05 at 16:01 +0100, Jiri Pirko wrote:

> I know. But makes more sense to have these getters here, near the
> struct. I originally moved the definitions near br_handle_frame_finish
> definition but I think that it is nicer to do it this way...

No, this is really ugly.
