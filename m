From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v2 3/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Wed, 8 Jan 2014 11:56:41 -0800
Message-ID: <CANJ5vPLsjKNbk0dkbK9KtJTYbaWM3jUJ+panme7-mMiDChT+tQ@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-3-git-send-email-mwdalton@google.com>
	<52CCEEF3.5070904@redhat.com>
	<CANJ5vP+btxgZg5kDq30KZTEXO7YBCL5TWoiRzjMqxnaA3Edkxw@mail.gmail.com>
	<20140108191623.GA18312@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140108191623.GA18312@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Eric, Michael,

On Wed, Jan 8, 2014 at 11:16 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> Why should we select a frame at random and make it's truesize bigger?
> All frames are to blame for the extra space.
> Just ignoring it seems more symmetrical.
Sounds good, based on Eric's feedback and Michael's feedback above,
I will leave the 'extra space' handling as-is in the followup patchset
and will not track the extra space in ctx->truesize. AFAICT, The two
max() statements will need to remain (as buffer length may exceed
ctx->truesize).  Thanks for the feedback.

> If you intend to repost anyway (for the below wrinkle) then
> you can do it right here just as well I guess. Seems a bit prettier.
Will do.

> You don't have to fill in ctx before calling add_inbuf, do you?
> Just fill it afterwards.
Agreed, ctx does not need to be filled until after add_inbuf.

Best,

Mike
