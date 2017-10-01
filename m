From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 0/3] support changing steering policies in tuntap
Date: Sun, 1 Oct 2017 06:28:04 +0300
Message-ID: <20171001062520-mutt-send-email-mst@kernel.org>
References: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
 <20170927230042-mutt-send-email-mst@kernel.org>
 <CAF=yD-J8hERZdwq8FJ2rtnCnZ2b7s=CAVLtPk4CS7e=RQH3sLQ@mail.gmail.com>
 <26f01b12-396e-6319-0eed-c987930e0ed9@redhat.com>
 <CAF=yD-KuDZK0-YUfYde=dk_6M6fgj_opuiK2VTfCKDM_=MqDcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAF=yD-KuDZK0-YUfYde=dk_6M6fgj_opuiK2VTfCKDM_=MqDcw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 12:09:05PM -0400, Willem de Bruijn wrote:
> Programming from the guest is
> indeed different. I don't fully understand that use case.

Generally programming host BPF from guest is a clear win - think DOS
protection. Guest runs logic to detect dos attacks, then passes the
program to host.  Afterwards, host does not need to enter guest if
there's a DOS attack. Saves a ton of cycles.

The difficulty is making it work well, e.g. how do we handle maps?

-- 
MST
