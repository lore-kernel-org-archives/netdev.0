From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: hung task in mac80211
Date: Wed, 6 Sep 2017 15:40:57 +0200
Message-ID: <20170906154057.2de430a2@elisabeth>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
        <20170906144019.1c98a636@elisabeth>
        <1504702115.13457.16.camel@sipsolutions.net>
        <20170906151922.4a320b1d@elisabeth>
        <1504704060.13457.20.camel@sipsolutions.net>
        <20170906152709.673f230d@elisabeth>
        <1504704610.23905.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <mcroce@redhat.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504704610.23905.1.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Sep 2017 15:30:10 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> So for example replacing the loop of tid = 0..NUM_TIDS-1 with a
> list_for_each_entry() would already be unsafe with the dropping if the
> list were to require the mutex for locking.

Sure. Still, it would need another code change to break, but in general
I do agree indeed. :)


--
Stefano
