From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/2] virito: introduce methods of fixing device features
Date: Wed, 26 Nov 2014 02:09:00 -0500 (EST)
Message-ID: <848153913.16119602.1416985740195.JavaMail.zimbra@redhat.com>
References: <1415857974-23326-1-git-send-email-jasowang@redhat.com>
	<87sih9xv5u.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87sih9xv5u.fsf@rustcorp.com.au>
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



----- Original Message -----
> Jason Wang <jasowang@redhat.com> writes:
> > Buggy host may advertised buggy host features (a usual case is that host
> > advertise a feature whose dependencies were missed). In this case, driver
> > should detect and disable the buggy features by itself.
> 
> Sorry, I've been focussing elsewhere.
> 
> I would really prefer that drivers offer a "feature_depends" table,
> which can indicate that feature A depends on feature B, and have the
> core iterate, complain and fixup as necessary.
> 
> Is that expressive enough, or do we need more?
> 
> Thanks,
> Rusty.

I suggested something like this in https://lkml.org/lkml/2014/11/19/132, but
Michael does not like it ...
