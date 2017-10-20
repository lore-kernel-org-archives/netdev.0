From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 18/27] bpf: Restrict kernel image access functions when the kernel is locked down
Date: Fri, 20 Oct 2017 09:08:48 +0100
Message-ID: <2582.1508486928@warthog.procyon.org.uk>
References: <20171020024732.GJ3285@linux-l9pv.suse> <150842463163.7923.11081723749106843698.stgit@warthog.procyon.org.uk> <150842476953.7923.18174368926573855810.stgit@warthog.procyon.org.uk> <20171019221829.7m5nczg3ltqmhzom@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        linux-security-module@vger.kernel.org, gnomes@lxorguk.ukuu.org.uk,
        linux-efi@vger.kernel.org, matthew.garrett@nebula.com,
        gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
        jforbes@redhat.com, Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Gary Lin <GLin@suse.com>
To: joeyli <jlee@suse.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20171020024732.GJ3285@linux-l9pv.suse>
Content-ID: <2581.1508486928.1@warthog.procyon.org.uk>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joey,

Should I just lock down sys_bpf() entirely for now?  We can always free it up
somewhat later.

David
