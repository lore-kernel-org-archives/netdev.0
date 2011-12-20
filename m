From: "Luis R. Rodriguez" <mcgrof@frijolero.org>
Subject: [ANN] compat-wireless for 3.2-rc6
Date: Mon, 19 Dec 2011 19:55:28 -0800
Message-ID: <CAB=NE6WfBDqQzqxNaZm5mMhjyP2t7M-5t=+RA-A2JAKUKjmJzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You all know what this is, only difference is we have a few
pending-stable patches not yet merged into Linus' tree but that are on
linux-next.git so we suck those in and provide an "-s" release. Below
are the statistics of both releases. We have an "-s" release [1] and a
vanilla release [2]. I'll note that I expect a few set of patches are
desirable to cherry pick from linux-next.git for a type of stable
release that we will support but for now I have yet to hear back which
patches those are. Feel free to reply here with the sha1sums you want
but please be specific of the linux-next.git tag you used.

For the -s release:

Updated from local tree: /home/mcgrof/linux-stable
Origin remote URL:
git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git

compat-wireless code metrics

    814570 - Total upstream lines of code being pulled
      2488 - backport code changes
      2143 - backport code additions
       345 - backport code deletions
      8670 - backport from compat module
     11158 - total backport code
    1.3698 - % of code consists of backport work
        57 - Code changes brought in from pending-stable
        44 - Code additions brought in from pending-stable
        13 - Code deletions brought in from pending-stable
    0.0070 - % of code being cherry picked from pending-stable

Base tree: linux-stable.git
Base tree version: v3.2-rc6
compat-wireless release: compat-wireless-v3.2-rc6-3-s

For the vanilla release:

Updated from local tree: /home/mcgrof/linux-stable
Origin remote URL:
git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git

compat-wireless code metrics

    814570 - Total upstream lines of code being pulled
      2488 - backport code changes
      2143 - backport code additions
       345 - backport code deletions
      8670 - backport from compat module
     11158 - total backport code
    1.3698 - % of code consists of backport work

Base tree: linux-stable.git
Base tree version: v3.2-rc6
compat-wireless release: compat-wireless-v3.2-rc6-3

[1] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.2/compat-wireless-3.2-rc6-3-s.tar.bz2
[2] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.2/compat-wireless-3.2-rc1-1.tar.bz2
