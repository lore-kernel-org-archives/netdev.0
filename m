From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC] kvm tools: Implement multiple VQ for virtio-net
Date: Wed, 16 Nov 2011 10:34:42 +1030
Message-ID: <877h31ortx.fsf@rustcorp.com.au>
References: <1321049521-26376-1-git-send-email-levinsasha928@gmail.com>
	<20111113102428.GD15322@redhat.com>
	<1321196430.2425.2.camel@sasha> <4EC07729.3050303@gmail.com>
	<CAOJsxLE4yRO+5XncrDEzVh5-RGXG+=HGTAmQ=bX=KMsDqf=feA@mail.gmail.com>
	<20111114130507.GA18288@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, kvm@vger.kernel.org,
	Asias He <asias.hejun@gmail.com>,
	virtualization@lists.linux-foundation.org, gorcunov@gmail.com,
	Sasha Levin <levinsasha928@gmail.com>, netdev@vger.kernel.org,
	mingo@elte.hu, Stephen Hemminger <shemminger@vyatta.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Pekka Enberg <penberg@kernel.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111114130507.GA18288@redhat.com>
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

On Mon, 14 Nov 2011 15:05:07 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Mon, Nov 14, 2011 at 02:25:17PM +0200, Pekka Enberg wrote:
> > On Mon, Nov 14, 2011 at 4:04 AM, Asias He <asias.hejun@gmail.com> wrote:
> > > Why both the bandwidth and latency performance are dropping so dramatically
> > > with multiple VQ?
> > 
> > What's the expected benefit from multiple VQs
> 
> Heh, the original patchset didn't mention this :) It really should.
> They are supposed to speed up networking for high smp guests.

If we have one queue per guest CPU, does this allow us to run lockless?

Thanks,
Rusty.
