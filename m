From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2] XDP Program for Ip forward
Date: Tue, 10 Oct 2017 16:00:57 +0200
Message-ID: <20171010160057.32678367@redhat.com>
References: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
        <20171010151231.69fde82f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, Sunil.Goutham@cavium.com,
        daniel@iogearbox.net, dsahern@gmail.com,
        Christina Jacob <Christina.Jacob@cavium.com>, brouer@redhat.com
To: Christina Jacob <christina.jacob.koikara@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010151231.69fde82f@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Oct 2017 15:12:31 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> I'll try to test/benchmark your program...

In my initial testing, I cannot get this to work...

You do seem to XDP_REDIRECT out the right interface, but you have an
error with setting the correct MAC address.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
