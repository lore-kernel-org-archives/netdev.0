From: Benjamin Serebrin <serebrin@google.com>
Subject: Re: [PATCH v2 net-next] virtio: Fix affinity for #VCPUs != #queue pairs
Date: Wed, 15 Feb 2017 14:13:55 -0800
Message-ID: <CAN+hb0UqC+FFf0n+rfjAC660SBA7ZFbO4F+LKipUMRBWVbHJjg@mail.gmail.com>
References: <20170207181506.36668-1-serebrin@google.com> <20170208205353-mutt-send-email-mst@kernel.org>
 <CAN+hb0Uen4_bHR8xPcUNZG+aKPYAvjUqY1Z4PA7WWOs7jG3EAA@mail.gmail.com>
 <20170214225629-mutt-send-email-mst@kernel.org> <CAF=yD-La6wL16Ej0jGw1ztiKOGpWoaY86E3Qe4KmskrjczrC_A@mail.gmail.com>
 <20170215185413-mutt-send-email-mst@kernel.org> <CAN+hb0V5hcMkWwQhk=5G4B+vWBARyEq+g-=XVaygH5s-s7mPZw@mail.gmail.com>
 <20170215210941-mutt-send-email-mst@kernel.org> <CAN+hb0X4UWmDvA0=5gpC6+Qt7vDgz0u5B79CM4KqQ-yuJmAO7Q@mail.gmail.com>
 <20170215234333-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        "Jon Olson (Google Drive)" <jonolson@google.com>,
        Rick Jones <rick.jones2@hpe.com>,
        James Mattson <jmattson@google.com>,
        linux-s390 <linux-s390@vger.kernel.org>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20170215234333-mutt-send-email-mst@kernel.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2017 at 1:49 PM, Michael S. Tsirkin <mst@redhat.com> wrote:

> The logic is simple really. With #VCPUs == #queues we can reasonably
> assume this box is mostly doing networking so we can set affinity
> the way we like. With VCPUs > queues clearly VM is doing more stuff
> so we need a userspace policy to take that into account,
> we don't know ourselves what is the right thing to do.
>
> Arguably for #VCPUs == #queues we are not always doing the right thing
> either but I see this as an argument to move more smarts
> into core kernel not for adding more dumb heuristics in the driver.

Thanks for all the feedback, Michael.  We'll drop this patch and move
to user mode.

Thanks,
Ben
